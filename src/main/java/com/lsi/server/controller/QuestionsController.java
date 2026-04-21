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
import com.lsi.server.model.geo.QuestionChoixGeo;
import com.lsi.server.repository.QuestionsChoixGeoRepository;
import com.lsi.server.repository.QuestionsRepository;
import com.lsi.server.repository.UserRepository;

@RestController
@RequestMapping("/question")
public class QuestionsController {

    @Autowired
    QuestionsRepository questionsRepository;
    
    @Autowired
    UserRepository userRepository;

    @Autowired
    QuestionsChoixGeoRepository qChoixGeoRepository;
    
    @GetMapping("/all")
    public List<Question> getAll() {
        return questionsRepository.findAll();
    }

    @PostMapping("/create")
    public Question create(@Valid @RequestBody Question question) {
        return questionsRepository.save(question);
    }
    
    @PostMapping("/geo/create")
    public QuestionChoixGeo createchoixGeo(@Valid @RequestBody QuestionChoixGeo choixGeo) {
        return qChoixGeoRepository.save(choixGeo);
    }

    @GetMapping("/{id}")
    public Question getQuestionById(@PathVariable(value = "id") Long questionId) {
    	return questionsRepository.findById(questionId)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionId));
    }
    
    @PostMapping("/user/{id}")
    public List<Question> getQuestionsByUser(@PathVariable(value = "id") Long userId) {
    	List<Question> questions = userRepository.findQuestionByUser(userId);
    	if(questions==null) throw new ResourceNotFoundException("Questions", "id", userId);
    	return questions;
    }

    @PutMapping("/update")
    public Question update(@Valid @RequestBody Question questionDetails) {
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
    	Question question = questionsRepository.findById(questionId)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionId));
        questionsRepository.delete(question);
        return ResponseEntity.ok().build();
    }
}
