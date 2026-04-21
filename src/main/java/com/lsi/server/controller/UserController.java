package com.lsi.server.controller;

import java.util.Date;
import java.util.List;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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

    @GetMapping("/all")
    public List<User> getAll() {
        SecurityUtils.requireAdmin();
        return userRepository.findAll();
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
        userRepository.delete(user);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{id}/questions")
    public List<Question> getQuestionsForUser(@PathVariable(value = "id") Long userId) {
        SecurityUtils.requireCurrentUserOrAdmin(userId);
    	List<Question> questions = userRepository.findQuestionForUser(userId);
    	if(questions==null) throw new ResourceNotFoundException("Questions", "id", userId);
    	return questions;
    }

    private User loadCurrentUser() {
        ApiPrincipal principal = SecurityUtils.currentPrincipal();
        return userRepository.findById(principal.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", principal.getUserId()));
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
}




