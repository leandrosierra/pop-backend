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
@Table(name="QUESTION_COMMENTS")
public class QuestionComment {

	@Id
	@Column(name="id_comment")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name="id_question")
	private Question question;

	@ManyToOne
	@JoinColumn(name="id_user")
	private User user;

	@ManyToOne
	@JoinColumn(name="id_parent_comment")
	private QuestionComment parentComment;

	private String contenu;

	@Column(name="date_creation")
	private Date dateCreation;

	@Column(name="date_modification")
	private Date dateModification;

	public QuestionComment() {
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

	public QuestionComment getParentComment() {
		return parentComment;
	}

	public void setParentComment(QuestionComment parentComment) {
		this.parentComment = parentComment;
	}

	public String getContenu() {
		return contenu;
	}

	public void setContenu(String contenu) {
		this.contenu = contenu;
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
