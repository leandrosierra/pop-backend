package com.lsi.server.controller;

import java.util.Date;
import java.util.List;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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
import com.lsi.server.model.User;
import com.lsi.server.repository.UserRepository;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    UserRepository userRepository;

    @GetMapping("/all")
    public List<User> getAll() {
        return userRepository.findAll();
    }

    @PostMapping("/create")
    public User create(@Valid @RequestBody User user) {
        return userRepository.save(user);
    }

    @GetMapping("/{id}")
    public User getUserById(@PathVariable(value = "id") Long userId) {
    	return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
    }
    
    @PostMapping("/login")
    public User login(@Valid @RequestBody User userToLog) {
    	User user = userRepository.findUserByLogin(userToLog.getLogin())
    			.orElseThrow(() -> new ResourceNotFoundException("User", "id", userToLog.getLogin()));
    	if(user.getPassword().equals(userToLog.getPassword())) return user;
    	else throw new ResourceNotFoundException("User", "password", userToLog.getPassword());
    }

    @PutMapping("/update")
    public User update(@Valid @RequestBody User userDetails) {
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userDetails.getId()));
        
        user.setNom(userDetails.getNom());
        user.setPrenom(userDetails.getPrenom());
        user.setActif(userDetails.isActif());
        user.setEmail(userDetails.getEmail());
        user.setRole(userDetails.getRole());
        user.setInterets(userDetails.getInterets());
        user.setChoixGeo(userDetails.getChoixGeo());
        user.setParametres(userDetails.getParametres());
        user.setAdresses(userDetails.getAdresses());
        user.setDateModification(new Date());

        User updatedUser = userRepository.save(user);
        return updatedUser;
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable(value = "id") Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        userRepository.delete(user);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{id}/questions")
    public List<Question> getQuestionsForUser(@PathVariable(value = "id") Long userId) {
    	List<Question> questions = userRepository.findQuestionForUser(userId);
    	if(questions==null) throw new ResourceNotFoundException("Questions", "id", userId);
    	return questions;
    }
}





