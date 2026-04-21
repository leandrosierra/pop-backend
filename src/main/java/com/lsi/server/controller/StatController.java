package com.lsi.server.controller;

import java.util.Date;
import java.util.List;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.lsi.server.exception.ResourceNotFoundException;
import com.lsi.server.model.Stat;
import com.lsi.server.repository.StatRepository;
import com.lsi.server.repository.UserRepository;

@RestController
@RequestMapping("/stat")
public class StatController {

    @Autowired
    StatRepository statRepository;
    
    @Autowired
    UserRepository userRepository;

    @GetMapping("/all")
    public List<Stat> getAll() {
        return statRepository.findAll();
    }

    @PostMapping("/create")
    public Stat create(@Valid @RequestBody Stat stat) {
        return statRepository.save(stat);
    }

    @GetMapping("/{id}")
    public Stat getStatById(@PathVariable(value = "id") Long statId) {
    	return statRepository.findById(statId)
                .orElseThrow(() -> new ResourceNotFoundException("Stat", "id", statId));
    }

    @PutMapping("/update")
    public Stat update(@Valid @RequestBody Stat statDetails) {
    	Stat stat = statRepository.findById(statDetails.getIdStat())
                .orElseThrow(() -> new ResourceNotFoundException("Stat", "id", statDetails.getIdStat()));
        
    	stat.setReponse(statDetails.getReponse());
    	stat.setDateModification(new Date());

    	Stat updatedStat = statRepository.save(stat);
        return updatedStat;
    }

}
