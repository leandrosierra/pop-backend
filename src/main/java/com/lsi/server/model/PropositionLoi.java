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
@Table(name="PROPOSITIONS_LOI")
public class PropositionLoi {

	@Id
	@Column(name="id_proposition_loi")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name="id_question")
	private Question question;

	@ManyToOne
	@JoinColumn(name="id_user")
	private User user;

	private String titre;

	@Column(name="expose_motifs")
	private String exposeMotifs;

	private String dispositif;

	@Column(name="analyse_conformite")
	private String analyseConformite;

	private String statut;

	@Column(name="date_creation")
	private Date dateCreation;

	@Column(name="date_modification")
	private Date dateModification;

	public PropositionLoi() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Question getQuestion() {
		return question;
	}

	public void setQuestion(Question question) {
		this.question = question;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public String getTitre() {
		return titre;
	}

	public void setTitre(String titre) {
		this.titre = titre;
	}

	public String getExposeMotifs() {
		return exposeMotifs;
	}

	public void setExposeMotifs(String exposeMotifs) {
		this.exposeMotifs = exposeMotifs;
	}

	public String getDispositif() {
		return dispositif;
	}

	public void setDispositif(String dispositif) {
		this.dispositif = dispositif;
	}

	public String getAnalyseConformite() {
		return analyseConformite;
	}

	public void setAnalyseConformite(String analyseConformite) {
		this.analyseConformite = analyseConformite;
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
