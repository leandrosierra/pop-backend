package com.lsi.server.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name="BUDGETS")
public class Budget {

	@Id
	@Column(name="id_budget")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String niveau;

	@Column(name="code_territoire")
	private String codeTerritoire;

	@Column(name="libelle_territoire")
	private String libelleTerritoire;

	private Integer annee;

	@Column(name="montant_total")
	private BigDecimal montantTotal;

	@OneToMany(targetEntity=BudgetPoste.class, mappedBy="budget")
	private List<BudgetPoste> postes = new ArrayList<>();

	@Column(name="date_creation")
	private Date dateCreation;

	@Column(name="date_modification")
	private Date dateModification;

	public Budget() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getNiveau() {
		return niveau;
	}

	public void setNiveau(String niveau) {
		this.niveau = niveau;
	}

	public String getCodeTerritoire() {
		return codeTerritoire;
	}

	public void setCodeTerritoire(String codeTerritoire) {
		this.codeTerritoire = codeTerritoire;
	}

	public String getLibelleTerritoire() {
		return libelleTerritoire;
	}

	public void setLibelleTerritoire(String libelleTerritoire) {
		this.libelleTerritoire = libelleTerritoire;
	}

	public Integer getAnnee() {
		return annee;
	}

	public void setAnnee(Integer annee) {
		this.annee = annee;
	}

	public BigDecimal getMontantTotal() {
		return montantTotal;
	}

	public void setMontantTotal(BigDecimal montantTotal) {
		this.montantTotal = montantTotal;
	}

	public List<BudgetPoste> getPostes() {
		return postes;
	}

	public void setPostes(List<BudgetPoste> postes) {
		this.postes = postes;
	}

	public Date getDateCreation() {
		return dateCreation;
	}

	public void setDateCreation(Date dateCreation) {
		this.dateCreation = dateCreation;
	}

	public Date getDateModification() {
		return dateModification;
	}

	public void setDateModification(Date dateModification) {
		this.dateModification = dateModification;
	}
}
