package com.lsi.server.controller;

import java.util.Calendar;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.lsi.server.exception.ResourceNotFoundException;
import com.lsi.server.model.Actualite;
import com.lsi.server.model.Question;
import com.lsi.server.model.QuestionSuggestion;
import com.lsi.server.model.Statut;
import com.lsi.server.repository.ActualiteRepository;
import com.lsi.server.repository.QuestionSuggestionRepository;
import com.lsi.server.repository.QuestionsRepository;
import com.lsi.server.repository.StatutRepository;
import com.lsi.server.repository.UserRepository;
import com.lsi.server.security.SecurityUtils;

@RestController
@RequestMapping("/actualite")
public class ActualiteController {

	@Autowired
	ActualiteRepository actualiteRepository;

	@Autowired
	QuestionSuggestionRepository suggestionRepository;

	@Autowired
	QuestionsRepository questionsRepository;

	@Autowired
	UserRepository userRepository;

	@Autowired
	StatutRepository statutRepository;

	@GetMapping("/all")
	public Page<Actualite> getAll(@PageableDefault(size = 10) Pageable pageable) {
		return actualiteRepository.findActualitesRecentes(pageable);
	}

	@PostMapping("/create")
	public Actualite create(@Valid @RequestBody Actualite actualite) {
		SecurityUtils.requireAdmin();
		actualite.setId(null);
		actualite.setDateCreation(new Date());
		return actualiteRepository.save(actualite);
	}

	@GetMapping("/suggestions")
	public Page<QuestionSuggestion> getSuggestions(@PageableDefault(size = 10) Pageable pageable) {
		return suggestionRepository.findSuggestionsRecentes(pageable);
	}

	@PostMapping("/{id}/question/suggest")
	public QuestionSuggestion suggestQuestion(@PathVariable(value = "id") Long actualiteId) {
		SecurityUtils.requireAdmin();
		Optional<QuestionSuggestion> existingSuggestion = suggestionRepository.findSuggestionByActualiteId(actualiteId);
		if (existingSuggestion.isPresent()) {
			return existingSuggestion.get();
		}
		long userId = SecurityUtils.currentPrincipal().getUserId();
		Actualite actualite = actualiteRepository.findById(actualiteId)
				.orElseThrow(() -> new ResourceNotFoundException("Actualite", "id", actualiteId));
		Statut actif = statutRepository.findStatutByCode("ACTIF")
				.orElseThrow(() -> new ResourceNotFoundException("Statut", "code", "ACTIF"));
		Question question = new Question();
		question.setUser(userRepository.findById(userId)
				.orElseThrow(() -> new ResourceNotFoundException("User", "id", userId)));
		question.setStatut(actif);
		question.setCode("ACTU-" + actualite.getId());
		question.setLibelle(limit("Faut-il agir sur " + actualite.getTitre(), 255));
		question.setDescription(actualite.getResume());
		question.setDateExpiration(expirationDate());
		question = questionsRepository.save(question);

		QuestionSuggestion suggestion = new QuestionSuggestion();
		suggestion.setActualite(actualite);
		suggestion.setQuestion(question);
		suggestion.setStatut("PUBLIEE");
		suggestion.setTitre(question.getLibelle());
		suggestion.setDescription(question.getDescription());
		suggestion.setDateCreation(new Date());
		return suggestionRepository.save(suggestion);
	}

	private Date expirationDate() {
		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.DAY_OF_MONTH, 30);
		return calendar.getTime();
	}

	private String limit(String value, int maxLength) {
		if (value == null || value.length() <= maxLength) {
			return value;
		}
		return value.substring(0, maxLength);
	}
}
