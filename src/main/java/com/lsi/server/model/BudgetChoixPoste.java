package com.lsi.server.model;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name="BUDGET_CHOIX_POSTES")
public class BudgetChoixPoste {

	@Id
	@Column(name="id_budget_choix_poste")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name="id_budget_choix")
	@JsonIgnore
	private BudgetChoix choix;

	@ManyToOne
	@JoinColumn(name="id_budget_poste")
	private BudgetPoste poste;

	private BigDecimal montant;

	public BudgetChoixPoste() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public BudgetChoix getChoix() {
		return choix;
	}

	public void setChoix(BudgetChoix choix) {
		this.choix = choix;
	}

	public BudgetPoste getPoste() {
		return poste;
	}

	public void setPoste(BudgetPoste poste) {
		this.poste = poste;
	}

	public BigDecimal getMontant() {
		return montant;
	}

	public void setMontant(BigDecimal montant) {
		this.montant = montant;
	}
}
