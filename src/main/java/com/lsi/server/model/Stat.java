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
@Table(name="QUESTIONS_STAT")
public class Stat  {

	@Id
	@Column(name="id_questions_stat")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long idStat;

	@ManyToOne
	@JoinColumn(name="id_question")
	private Question question;

	@ManyToOne
	@JoinColumn(name="id_answer")
	private Reponse reponse;
	
	@ManyToOne
	@JoinColumn(name="id_user")
	private User user;

	@Column(name="date_creation")
	private Date dateCreation;

	@Column(name="date_modification")
	private Date dateModification;
	
	
	public Stat() {
	}


	public Long getIdStat() {
		return idStat;
	}


	public void setIdStat(Long idStat) {
		this.idStat = idStat;
	}


	public Question getQuestion() {
		return question;
	}


	public void setQuestion(Question question) {
		this.question = question;
	}


	public Reponse getReponse() {
		return reponse;
	}


	public void setReponse(Reponse reponse) {
		this.reponse = reponse;
	}


	public User getUser() {
		return user;
	}


	public void setUser(User user) {
		this.user = user;
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