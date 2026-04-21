package com.lsi.server.controller;

import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.lsi.server.exception.ResourceNotFoundException;
import com.lsi.server.model.Question;
import com.lsi.server.model.Role;
import com.lsi.server.model.User;
import com.lsi.server.repository.RoleRepository;
import com.lsi.server.repository.UserRepository;
import com.lsi.server.security.ApiPrincipal;
import com.lsi.server.security.SecurityUtils;
import com.lsi.server.security.TokenService;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    UserRepository userRepository;

    @Autowired
    RoleRepository roleRepository;

    @Autowired
    PasswordEncoder passwordEncoder;

    @Autowired
    TokenService tokenService;

    @Autowired
    JdbcTemplate jdbcTemplate;

    @GetMapping("/all")
    public Page<User> getAll(@PageableDefault(size = 10) Pageable pageable) {
        SecurityUtils.requireAdmin();
        return userRepository.findAll(pageable);
    }

    @PostMapping("/create")
    public User create(@Valid @RequestBody User user) {
        Role userRole = roleRepository.findRoleByCode("USER")
                .orElseThrow(() -> new ResourceNotFoundException("Role", "code", "USER"));
        user.setRole(userRole);
        user.setActif(true);
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    @GetMapping("/current")
    public User getCurrentUser() {
        return loadCurrentUser();
    }

    @DeleteMapping("/current")
    public ResponseEntity<?> deleteCurrentUser() {
        User user = loadCurrentUser();
        rejectAdminDeletion(user);
        userRepository.delete(user);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/current/password")
    public ResponseEntity<?> updateCurrentPassword(@Valid @RequestBody User userDetails) {
        User user = loadCurrentUser();
        user.setPassword(passwordEncoder.encode(userDetails.getPassword()));
        user.setDateModification(new Date());
        userRepository.save(user);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/current/language")
    public LanguageResponse getCurrentLanguage() {
        return new LanguageResponse(readLanguageCode(loadCurrentUser()));
    }

    @PutMapping("/current/language")
    public LanguageResponse updateCurrentLanguage(@RequestBody LanguageRequest languageRequest) {
        User user = loadCurrentUser();
        String code = normalizeLanguageCode(languageRequest == null ? null : languageRequest.getCode());
        List<Integer> languageIds = jdbcTemplate.queryForList(
                "SELECT id_langue FROM LANGUES_REF WHERE UPPER(code) = ? LIMIT 1",
                Integer.class,
                code);
        if (languageIds.isEmpty()) {
            throw new ResourceNotFoundException("Language", "code", code);
        }

        int parameterId = user.getParametres().getIdParametre();
        jdbcTemplate.update("DELETE FROM USER_PARAMETRES_LANGUE WHERE id_parametre = ?", parameterId);
        jdbcTemplate.update(
                "INSERT INTO USER_PARAMETRES_LANGUE (id_parametre, id_langue, ordre) VALUES (?, ?, 1)",
                parameterId,
                languageIds.get(0));
        user.setDateModification(new Date());
        userRepository.save(user);
        return new LanguageResponse(code);
    }

    @GetMapping("/{id}")
    public User getUserById(@PathVariable(value = "id") Long userId) {
        SecurityUtils.requireCurrentUserOrAdmin(userId);
    	return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
    }
    
    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody User userToLog) {
    	User user = userRepository.findUserByLogin(userToLog.getLogin())
    			.orElseThrow(() -> new SecurityException("Unauthorized"));
        if(!user.isActif() || !matchesPassword(userToLog.getPassword(), user)) {
            throw new SecurityException("Unauthorized");
        }
        String role = user.getRole() != null && user.getRole().getCode() != null ? user.getRole().getCode() : "USER";
        String token = tokenService.createToken(user.getId(), role);
    	return new LoginResponse(token, token, user);
    }

    @PutMapping("/update")
    public User update(@Valid @RequestBody User userDetails) {
        SecurityUtils.requireCurrentUserOrAdmin(userDetails.getId());
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userDetails.getId()));
        
        user.setNom(userDetails.getNom());
        user.setPrenom(userDetails.getPrenom());
        user.setEmail(userDetails.getEmail());
        user.setInterets(userDetails.getInterets());
        user.setChoixGeo(userDetails.getChoixGeo());
        user.setParametres(userDetails.getParametres());
        user.setAdresses(userDetails.getAdresses());
        if (SecurityUtils.currentPrincipal().isAdmin()) {
            user.setActif(userDetails.isActif());
            user.setRole(userDetails.getRole());
        }
        user.setDateModification(new Date());

        User updatedUser = userRepository.save(user);
        return updatedUser;
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable(value = "id") Long userId) {
        SecurityUtils.requireCurrentUserOrAdmin(userId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        rejectAdminDeletion(user);
        userRepository.delete(user);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{id}/questions")
    public Page<Question> getQuestionsForUser(@PathVariable(value = "id") Long userId,
            @PageableDefault(size = 10) Pageable pageable) {
        SecurityUtils.requireCurrentUserOrAdmin(userId);
        return userRepository.findQuestionForUser(userId, pageable);
    }

    private User loadCurrentUser() {
        ApiPrincipal principal = SecurityUtils.currentPrincipal();
        return userRepository.findById(principal.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", principal.getUserId()));
    }

    private String readLanguageCode(User user) {
        if (user.getParametres() == null) {
            return "FR";
        }

        List<String> codes = jdbcTemplate.queryForList(
                "SELECT l.code FROM USER_PARAMETRES_LANGUE upl " +
                        "JOIN LANGUES_REF l ON l.id_langue = upl.id_langue " +
                        "WHERE upl.id_parametre = ? " +
                        "ORDER BY COALESCE(upl.ordre, 0), l.id_langue LIMIT 1",
                String.class,
                user.getParametres().getIdParametre());
        return codes.isEmpty() ? "FR" : normalizeLanguageCode(codes.get(0));
    }

    private String normalizeLanguageCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return "FR";
        }
        return code.trim().toUpperCase(Locale.ROOT);
    }

    private void rejectAdminDeletion(User user) {
        if (user.getRole() != null && "ADMIN".equals(user.getRole().getCode())) {
            throw new SecurityException("Forbidden");
        }
    }

    private boolean matchesPassword(String rawPassword, User user) {
        String storedPassword = user.getPassword();
        if (storedPassword == null || rawPassword == null) {
            return false;
        }
        if (storedPassword.startsWith("$2a$") || storedPassword.startsWith("$2b$") || storedPassword.startsWith("$2y$")) {
            return passwordEncoder.matches(rawPassword, storedPassword);
        }
        if (!storedPassword.equals(rawPassword)) {
            return false;
        }
        user.setPassword(passwordEncoder.encode(rawPassword));
        user.setDateModification(new Date());
        userRepository.save(user);
        return true;
    }

    public static class LoginResponse {
        private String token;
        private String refreshToken;
        private User user;

        public LoginResponse(String token, String refreshToken, User user) {
            this.token = token;
            this.refreshToken = refreshToken;
            this.user = user;
        }

        public String getToken() {
            return token;
        }

        public String getRefreshToken() {
            return refreshToken;
        }

        public User getUser() {
            return user;
        }
    }

    public static class LanguageRequest {
        private String code;

        public String getCode() {
            return code;
        }

        public void setCode(String code) {
            this.code = code;
        }
    }

    public static class LanguageResponse {
        private String code;

        public LanguageResponse(String code) {
            this.code = code;
        }

        public String getCode() {
            return code;
        }
    }
}
