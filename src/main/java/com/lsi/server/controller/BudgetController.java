package com.lsi.server.controller;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import javax.transaction.Transactional;
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
import com.lsi.server.model.Budget;
import com.lsi.server.model.BudgetChoix;
import com.lsi.server.model.BudgetChoixPoste;
import com.lsi.server.model.BudgetChoixResult;
import com.lsi.server.model.BudgetImpact;
import com.lsi.server.model.BudgetPoste;
import com.lsi.server.repository.BudgetChoixPosteRepository;
import com.lsi.server.repository.BudgetChoixRepository;
import com.lsi.server.repository.BudgetImpactRepository;
import com.lsi.server.repository.BudgetPosteRepository;
import com.lsi.server.repository.BudgetRepository;
import com.lsi.server.repository.UserRepository;
import com.lsi.server.security.SecurityUtils;

@RestController
@RequestMapping("/budget")
public class BudgetController {

	@Autowired
	BudgetRepository budgetRepository;

	@Autowired
	BudgetPosteRepository posteRepository;

	@Autowired
	BudgetImpactRepository impactRepository;

	@Autowired
	BudgetChoixRepository choixRepository;

	@Autowired
	BudgetChoixPosteRepository allocationRepository;

	@Autowired
	UserRepository userRepository;

	@GetMapping("/all")
	public Page<Budget> getAll(@PageableDefault(size = 10) Pageable pageable) {
		SecurityUtils.requireAdmin();
		return budgetRepository.findAll(pageable);
	}

	@GetMapping("/{id}")
	public Budget getBudgetById(@PathVariable(value = "id") Long budgetId) {
		return budgetRepository.findById(budgetId)
				.orElseThrow(() -> new ResourceNotFoundException("Budget", "id", budgetId));
	}

	@GetMapping("/territoire/{niveau}/{code}")
	public Page<Budget> getBudgetsByTerritoire(@PathVariable(value = "niveau") String niveau,
			@PathVariable(value = "code") String codeTerritoire,
			@PageableDefault(size = 10) Pageable pageable) {
		return budgetRepository.findBudgetsByTerritoire(niveau, codeTerritoire, pageable);
	}

	@PostMapping("/create")
	public Budget createBudget(@Valid @RequestBody Budget budget) {
		SecurityUtils.requireAdmin();
		budget.setId(null);
		budget.setDateCreation(new Date());
		return budgetRepository.save(budget);
	}

	@PostMapping("/{id}/poste/create")
	public BudgetPoste createPoste(@PathVariable(value = "id") Long budgetId,
			@Valid @RequestBody BudgetPoste poste) {
		SecurityUtils.requireAdmin();
		Budget budget = budgetRepository.findById(budgetId)
				.orElseThrow(() -> new ResourceNotFoundException("Budget", "id", budgetId));
		poste.setId(null);
		poste.setBudget(budget);
		return posteRepository.save(poste);
	}

	@PostMapping("/poste/{id}/impact/create")
	public BudgetImpact createImpact(@PathVariable(value = "id") Long posteId,
			@Valid @RequestBody BudgetImpact impact) {
		SecurityUtils.requireAdmin();
		BudgetPoste poste = posteRepository.findById(posteId)
				.orElseThrow(() -> new ResourceNotFoundException("BudgetPoste", "id", posteId));
		impact.setId(null);
		impact.setPoste(poste);
		return impactRepository.save(impact);
	}

	@GetMapping("/choix/user/current")
	public Page<BudgetChoix> getCurrentUserChoix(@PageableDefault(size = 10) Pageable pageable) {
		long userId = SecurityUtils.currentPrincipal().getUserId();
		return choixRepository.findChoixByUserId(userId, pageable);
	}

	@GetMapping("/choix/{id}")
	public BudgetChoix getChoixById(@PathVariable(value = "id") Long choixId) {
		BudgetChoix choix = choixRepository.findById(choixId)
				.orElseThrow(() -> new ResourceNotFoundException("BudgetChoix", "id", choixId));
		requireChoixOwnerOrAdmin(choix);
		return choix;
	}

	@GetMapping("/choix/{id}/impacts")
	public List<BudgetImpact> getChoixImpacts(@PathVariable(value = "id") Long choixId) {
		BudgetChoix choix = choixRepository.findById(choixId)
				.orElseThrow(() -> new ResourceNotFoundException("BudgetChoix", "id", choixId));
		requireChoixOwnerOrAdmin(choix);
		return resolveImpacts(allocationRepository.findAllocationsByChoixId(choixId));
	}

	@PostMapping("/choix/create")
	@Transactional
	public BudgetChoixResult createChoix(@Valid @RequestBody BudgetChoix choixDetails) {
		long userId = SecurityUtils.currentPrincipal().getUserId();
		Budget budget = budgetRepository.findById(choixDetails.getBudget().getId())
				.orElseThrow(() -> new ResourceNotFoundException("Budget", "id", choixDetails.getBudget().getId()));
		Optional<BudgetChoix> existingChoix = choixRepository.findChoixByBudgetAndUser(budget.getId(), userId);
		BudgetChoix choix = existingChoix.orElse(new BudgetChoix());
		Date now = new Date();
		if (choix.getId() == null) {
			choix.setDateCreation(now);
		} else {
			choix.setDateModification(now);
			allocationRepository.deleteAll(allocationRepository.findAllocationsByChoixId(choix.getId()));
		}
		choix.setBudget(budget);
		choix.setUser(userRepository.findById(userId)
				.orElseThrow(() -> new ResourceNotFoundException("User", "id", userId)));
		choix = choixRepository.save(choix);

		List<BudgetChoixPoste> allocations = new ArrayList<>();
		for (BudgetChoixPoste allocationDetails : choixDetails.getAllocations()) {
			BudgetPoste poste = posteRepository.findById(allocationDetails.getPoste().getId())
					.orElseThrow(() -> new ResourceNotFoundException("BudgetPoste", "id", allocationDetails.getPoste().getId()));
			if (poste.getBudget() == null || !poste.getBudget().getId().equals(budget.getId())) {
				throw new SecurityException("Forbidden");
			}
			BudgetChoixPoste allocation = new BudgetChoixPoste();
			allocation.setChoix(choix);
			allocation.setPoste(poste);
			allocation.setMontant(allocationDetails.getMontant());
			allocations.add(allocationRepository.save(allocation));
		}
		choix.setAllocations(allocations);
		return new BudgetChoixResult(choix, resolveImpacts(allocations));
	}

	private List<BudgetImpact> resolveImpacts(List<BudgetChoixPoste> allocations) {
		List<BudgetImpact> impacts = new ArrayList<>();
		for (BudgetChoixPoste allocation : allocations) {
			BigDecimal montantActuel = allocation.getPoste().getMontantActuel();
			BigDecimal montantChoisi = allocation.getMontant();
			if (montantActuel != null && montantChoisi != null && montantActuel.compareTo(BigDecimal.ZERO) > 0) {
				BigDecimal delta = montantChoisi.subtract(montantActuel)
						.multiply(new BigDecimal("100"))
						.divide(montantActuel, 2, RoundingMode.HALF_UP);
				for (BudgetImpact impact : impactRepository.findImpactsByPosteId(allocation.getPoste().getId())) {
					BigDecimal seuil = impact.getSeuilPourcentage() == null ? BigDecimal.ZERO : impact.getSeuilPourcentage().abs();
					if ("POSITIF".equals(impact.getSens()) && delta.compareTo(seuil) >= 0) {
						impacts.add(impact);
					}
					if ("NEGATIF".equals(impact.getSens()) && delta.compareTo(seuil.negate()) <= 0) {
						impacts.add(impact);
					}
				}
			}
		}
		return impacts;
	}

	private void requireChoixOwnerOrAdmin(BudgetChoix choix) {
		if (choix.getUser() == null || !SecurityUtils.isCurrentUserOrAdmin(choix.getUser().getId())) {
			throw new SecurityException("Forbidden");
		}
	}
}
