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
@Table(name="BUDGET_IMPACTS")
public class BudgetImpact {

	@Id
	@Column(name="id_budget_impact")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name="id_budget_poste")
	@JsonIgnore
	private BudgetPoste poste;

	private String sens;

	private String libelle;

	private String description;

	@Column(name="seuil_pourcentage")
	private BigDecimal seuilPourcentage;

	public BudgetImpact() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public BudgetPoste getPoste() {
		return poste;
	}

	public void setPoste(BudgetPoste poste) {
		this.poste = poste;
	}

	public String getSens() {
		return sens;
	}

	public void setSens(String sens) {
		this.sens = sens;
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

	public BigDecimal getSeuilPourcentage() {
		return seuilPourcentage;
	}

	public void setSeuilPourcentage(BigDecimal seuilPourcentage) {
		this.seuilPourcentage = seuilPourcentage;
	}
}
