package com.lsi.server.controller;

import java.util.Date;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
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
import com.lsi.server.model.Statut;
import com.lsi.server.model.geo.QuestionChoixGeo;
import com.lsi.server.repository.QuestionsChoixGeoRepository;
import com.lsi.server.repository.QuestionsRepository;
import com.lsi.server.repository.StatutRepository;
import com.lsi.server.repository.UserRepository;
import com.lsi.server.security.ApiPrincipal;
import com.lsi.server.security.SecurityUtils;

@RestController
@RequestMapping("/question")
public class QuestionsController {

    @Autowired
    QuestionsRepository questionsRepository;
    
    @Autowired
    UserRepository userRepository;

    @Autowired
    StatutRepository statutRepository;

    @Autowired
    QuestionsChoixGeoRepository qChoixGeoRepository;
    
    @GetMapping("/all")
    public Page<Question> getAll(@PageableDefault(size = 10) Pageable pageable) {
        SecurityUtils.requireAdmin();
        return questionsRepository.findAll(pageable);
    }

    @GetMapping("/feed")
    public Page<Question> getFeed(@PageableDefault(size = 10) Pageable pageable) {
        return questionsRepository.findQuestionsByStatutCode("ACTIF", pageable);
    }

    @PostMapping("/create")
    public Question create(@Valid @RequestBody Question question) {
        long userId = SecurityUtils.currentPrincipal().getUserId();
        Statut draftStatus = statutRepository.findStatutByCode("BROUILLON")
                .orElseThrow(() -> new ResourceNotFoundException("Statut", "code", "BROUILLON"));
        question.setId(0);
        question.setUser(userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId)));
        question.setStatut(draftStatus);
        return questionsRepository.save(question);
    }
    
    @PostMapping("/geo/create")
    public QuestionChoixGeo createchoixGeo(@Valid @RequestBody QuestionChoixGeo choixGeo) {
        SecurityUtils.requireAdmin();
        return qChoixGeoRepository.save(choixGeo);
    }

    @GetMapping("/{id}")
    public Question getQuestionById(@PathVariable(value = "id") Long questionId) {
    	Question question = questionsRepository.findById(questionId)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionId));
        if (!canReadQuestion(question)) {
            throw new SecurityException("Forbidden");
        }
        return question;
    }
    
    @GetMapping("/user/current")
    public Page<Question> getCurrentUserQuestions(@PageableDefault(size = 10) Pageable pageable) {
        long userId = SecurityUtils.currentPrincipal().getUserId();
        return userRepository.findQuestionByUser(userId, pageable);
    }

    @PostMapping("/user/{id}")
    public Page<Question> getQuestionsByUser(@PathVariable(value = "id") Long userId,
            @PageableDefault(size = 10) Pageable pageable) {
        SecurityUtils.requireCurrentUserOrAdmin(userId);
        return userRepository.findQuestionByUser(userId, pageable);
    }

    @PutMapping("/update")
    public Question update(@Valid @RequestBody Question questionDetails) {
        SecurityUtils.requireAdmin();
    	Question question = questionsRepository.findById(questionDetails.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionDetails.getId()));
        
    	question.setLibelle(questionDetails.getLibelle());
    	question.setDescription(questionDetails.getDescription());
    	question.setForwards(questionDetails.getForwards());
    	question.setImage(questionDetails.getImage());
    	question.setStatut(questionDetails.getStatut());
        question.setDateModification(new Date());

        Question updatedQuestion = questionsRepository.save(question);
        return updatedQuestion;
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable(value = "id") Long questionId) {
        SecurityUtils.requireAdmin();
    	Question question = questionsRepository.findById(questionId)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionId));
        questionsRepository.delete(question);
        return ResponseEntity.ok().build();
    }

    private boolean canReadQuestion(Question question) {
        ApiPrincipal principal = SecurityUtils.currentPrincipal();
        if (principal.isAdmin()) {
            return true;
        }
        if (question.getUser() != null && question.getUser().getId() == principal.getUserId()) {
            return true;
        }
        return question.getStatut() != null && "ACTIF".equals(question.getStatut().getCode());
    }
}
