package com.lsi.server.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name="LOI_INCOHERENCES")
public class LoiIncoherence {

	@Id
	@Column(name="id_loi_incoherence")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name="id_loi")
	private Loi loi;

	@ManyToOne
	@JoinColumn(name="id_loi_reference")
	private Loi loiReference;

	private String description;

	@Column(name="correction_proposee")
	private String correctionProposee;

	private String statut;

	@Column(name="date_creation")
	private Date dateCreation;

	@Column(name="date_modification")
	private Date dateModification;

	public LoiIncoherence() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Loi getLoi() {
		return loi;
	}

	public void setLoi(Loi loi) {
		this.loi = loi;
	}

	public Loi getLoiReference() {
		return loiReference;
	}

	public void setLoiReference(Loi loiReference) {
		this.loiReference = loiReference;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getCorrectionProposee() {
		return correctionProposee;
	}

	public void setCorrectionProposee(String correctionProposee) {
		this.correctionProposee = correctionProposee;
	}

	public String getStatut() {
		return statut;
	}

	public void setStatut(String statut) {
		this.statut = statut;
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
