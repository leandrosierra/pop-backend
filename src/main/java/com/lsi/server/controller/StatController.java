package com.lsi.server.controller;

import java.util.Date;
import java.util.Optional;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.lsi.server.exception.ResourceNotFoundException;
import com.lsi.server.model.Question;
import com.lsi.server.model.Stat;
import com.lsi.server.repository.QuestionsRepository;
import com.lsi.server.repository.StatRepository;
import com.lsi.server.repository.UserRepository;
import com.lsi.server.security.ApiPrincipal;
import com.lsi.server.security.SecurityUtils;

@RestController
@RequestMapping("/stat")
public class StatController {

    @Autowired
    StatRepository statRepository;
    
    @Autowired
    UserRepository userRepository;

    @Autowired
    QuestionsRepository questionsRepository;

    @GetMapping("/all")
    public Page<Stat> getAll(@PageableDefault(size = 10) Pageable pageable) {
        SecurityUtils.requireAdmin();
        return statRepository.findAll(pageable);
    }

    @GetMapping("/question/{id}")
    public Page<Stat> getStatsByQuestion(@PathVariable(value = "id") Long questionId,
            @PageableDefault(size = 10) Pageable pageable) {
        Question question = questionsRepository.findById(questionId)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionId));
        if (!canReadQuestionStats(question)) {
            throw new SecurityException("Forbidden");
        }
        return statRepository.findStatsByQuestionId(questionId, pageable);
    }

    @GetMapping("/user/current")
    public Page<Stat> getCurrentUserStats(@PageableDefault(size = 10) Pageable pageable) {
        long userId = SecurityUtils.currentPrincipal().getUserId();
        return statRepository.findStatsByUserId(userId, pageable);
    }

    @PostMapping("/create")
    public Stat create(@Valid @RequestBody Stat stat) {
        long userId = SecurityUtils.currentPrincipal().getUserId();
        Question question = questionsRepository.findById(stat.getQuestion().getId())
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", stat.getQuestion().getId()));
        stat.setQuestion(question);
        stat.setUser(userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId)));
        Optional<Stat> existingStat = statRepository.findStatByQuestionAndUser(question.getId(), userId);
        if (existingStat.isPresent()) {
            Stat existing = existingStat.get();
            existing.setReponse(stat.getReponse());
            existing.setDateModification(new Date());
            return statRepository.save(existing);
        }
        return statRepository.save(stat);
    }

    @GetMapping("/{id}")
    public Stat getStatById(@PathVariable(value = "id") Long statId) {
    	Stat stat = statRepository.findById(statId)
                .orElseThrow(() -> new ResourceNotFoundException("Stat", "id", statId));
        if (!canAccessStat(stat)) {
            throw new SecurityException("Forbidden");
        }
        return stat;
    }

    @PutMapping("/update")
    public Stat update(@Valid @RequestBody Stat statDetails) {
    	Stat stat = statRepository.findById(statDetails.getIdStat())
                .orElseThrow(() -> new ResourceNotFoundException("Stat", "id", statDetails.getIdStat()));
        if (!canAccessStat(stat)) {
            throw new SecurityException("Forbidden");
        }
        
    	stat.setReponse(statDetails.getReponse());
    	stat.setDateModification(new Date());

    	Stat updatedStat = statRepository.save(stat);
        return updatedStat;
    }

    private boolean canReadQuestionStats(Question question) {
        ApiPrincipal principal = SecurityUtils.currentPrincipal();
        if (principal.isAdmin()) {
            return true;
        }
        if (question.getUser() != null && question.getUser().getId() == principal.getUserId()) {
            return true;
        }
        return question.getStatut() != null && "ACTIF".equals(question.getStatut().getCode());
    }

    private boolean canAccessStat(Stat stat) {
        ApiPrincipal principal = SecurityUtils.currentPrincipal();
        if (principal.isAdmin()) {
            return true;
        }
        if (stat.getUser() != null && stat.getUser().getId() == principal.getUserId()) {
            return true;
        }
        return stat.getQuestion() != null
                && stat.getQuestion().getUser() != null
                && stat.getQuestion().getUser().getId() == principal.getUserId();
    }
}
