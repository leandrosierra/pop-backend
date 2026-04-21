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
import com.lsi.server.model.Loi;
import com.lsi.server.model.LoiIncoherence;
import com.lsi.server.model.PropositionLoi;
import com.lsi.server.model.Question;
import com.lsi.server.repository.LoiIncoherenceRepository;
import com.lsi.server.repository.LoiRepository;
import com.lsi.server.repository.PropositionLoiRepository;
import com.lsi.server.repository.QuestionsRepository;
import com.lsi.server.repository.UserRepository;
import com.lsi.server.security.ApiPrincipal;
import com.lsi.server.security.SecurityUtils;

@RestController
@RequestMapping("/loi")
public class LoiController {

	@Autowired
	LoiRepository loiRepository;

	@Autowired
	LoiIncoherenceRepository incoherenceRepository;

	@Autowired
	PropositionLoiRepository propositionRepository;

	@Autowired
	QuestionsRepository questionsRepository;

	@Autowired
	UserRepository userRepository;

	@GetMapping("/all")
	public List<Loi> getAll() {
		return loiRepository.findAll();
	}

	@GetMapping("/{id}")
	public Loi getById(@PathVariable(value = "id") Long loiId) {
		return loiRepository.findById(loiId)
				.orElseThrow(() -> new ResourceNotFoundException("Loi", "id", loiId));
	}

	@PostMapping("/create")
	public Loi create(@Valid @RequestBody Loi loi) {
		SecurityUtils.requireAdmin();
		loi.setId(null);
		loi.setDateCreation(new Date());
		return loiRepository.save(loi);
	}

	@PutMapping("/update")
	public Loi update(@Valid @RequestBody Loi loiDetails) {
		SecurityUtils.requireAdmin();
		Loi loi = loiRepository.findById(loiDetails.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Loi", "id", loiDetails.getId()));
		loi.setCode(loiDetails.getCode());
		loi.setTitre(loiDetails.getTitre());
		loi.setContenu(loiDetails.getContenu());
		loi.setSource(loiDetails.getSource());
		loi.setDatePublication(loiDetails.getDatePublication());
		loi.setDateModification(new Date());
		return loiRepository.save(loi);
	}

	@GetMapping("/incoherence/all")
	public List<LoiIncoherence> getAllIncoherences() {
		return incoherenceRepository.findAll();
	}

	@GetMapping("/{id}/incoherences")
	public List<LoiIncoherence> getIncoherencesByLoi(@PathVariable(value = "id") Long loiId) {
		loiRepository.findById(loiId)
				.orElseThrow(() -> new ResourceNotFoundException("Loi", "id", loiId));
		return incoherenceRepository.findIncoherencesByLoiId(loiId);
	}

	@PostMapping("/incoherence/create")
	public LoiIncoherence createIncoherence(@Valid @RequestBody LoiIncoherence incoherence) {
		SecurityUtils.requireAdmin();
		Loi loi = loiRepository.findById(incoherence.getLoi().getId())
				.orElseThrow(() -> new ResourceNotFoundException("Loi", "id", incoherence.getLoi().getId()));
		Loi loiReference = loiRepository.findById(incoherence.getLoiReference().getId())
				.orElseThrow(() -> new ResourceNotFoundException("Loi", "id", incoherence.getLoiReference().getId()));
		incoherence.setId(null);
		incoherence.setLoi(loi);
		incoherence.setLoiReference(loiReference);
		incoherence.setDateCreation(new Date());
		return incoherenceRepository.save(incoherence);
	}

	@GetMapping("/proposition/all")
	public List<PropositionLoi> getAllPropositions() {
		SecurityUtils.requireAdmin();
		return propositionRepository.findAll();
	}

	@GetMapping("/proposition/question/{id}")
	public List<PropositionLoi> getPropositionsByQuestion(@PathVariable(value = "id") Long questionId) {
		Question question = getReadableQuestion(questionId);
		return propositionRepository.findPropositionsByQuestionId(question.getId());
	}

	@GetMapping("/proposition/user/current")
	public List<PropositionLoi> getCurrentUserPropositions() {
		long userId = SecurityUtils.currentPrincipal().getUserId();
		return propositionRepository.findPropositionsByUserId(userId);
	}

	@PostMapping("/proposition/create")
	public PropositionLoi createProposition(@Valid @RequestBody PropositionLoi proposition) {
		long userId = SecurityUtils.currentPrincipal().getUserId();
		Question question = getReadableQuestion(proposition.getQuestion().getId());
		proposition.setId(null);
		proposition.setQuestion(question);
		proposition.setUser(userRepository.findById(userId)
				.orElseThrow(() -> new ResourceNotFoundException("User", "id", userId)));
		proposition.setDateCreation(new Date());
		return propositionRepository.save(proposition);
	}

	@PutMapping("/proposition/update")
	public PropositionLoi updateProposition(@Valid @RequestBody PropositionLoi propositionDetails) {
		PropositionLoi proposition = propositionRepository.findById(propositionDetails.getId())
				.orElseThrow(() -> new ResourceNotFoundException("PropositionLoi", "id", propositionDetails.getId()));
		if (proposition.getUser() == null || !SecurityUtils.isCurrentUserOrAdmin(proposition.getUser().getId())) {
			throw new SecurityException("Forbidden");
		}
		proposition.setTitre(propositionDetails.getTitre());
		proposition.setExposeMotifs(propositionDetails.getExposeMotifs());
		proposition.setDispositif(propositionDetails.getDispositif());
		proposition.setAnalyseConformite(propositionDetails.getAnalyseConformite());
		proposition.setStatut(propositionDetails.getStatut());
		proposition.setDateModification(new Date());
		return propositionRepository.save(proposition);
	}

	private Question getReadableQuestion(Long questionId) {
		Question question = questionsRepository.findById(questionId)
				.orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionId));
		if (!canReadQuestion(question)) {
			throw new SecurityException("Forbidden");
		}
		return question;
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
