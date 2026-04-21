package com.lsi.server.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name="BUDGET_POSTES")
public class BudgetPoste {

	@Id
	@Column(name="id_budget_poste")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name="id_budget")
	@JsonIgnore
	private Budget budget;

	private String code;

	private String libelle;

	private String description;

	@Column(name="montant_actuel")
	private BigDecimal montantActuel;

	@OneToMany(targetEntity=BudgetImpact.class, mappedBy="poste")
	private List<BudgetImpact> impacts = new ArrayList<>();

	public BudgetPoste() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Budget getBudget() {
		return budget;
	}

	public void setBudget(Budget budget) {
		this.budget = budget;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getLibelle() {
		return libelle;
	}

	public void setLibelle(String libelle) {
		this.libelle = libelle;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public BigDecimal getMontantActuel() {
		return montantActuel;
	}

	public void setMontantActuel(BigDecimal montantActuel) {
		this.montantActuel = montantActuel;
	}

	public List<BudgetImpact> getImpacts() {
		return impacts;
	}

	public void setImpacts(List<BudgetImpact> impacts) {
		this.impacts = impacts;
	}
}
