package com.lsi.server.model;

import java.util.ArrayList;
import java.util.Date;
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

import com.lsi.server.model.geo.QuestionChoixGeo;

@Entity
@Table(name="QUESTIONS")
public class Question {
	
	@Id
	@Column(name="id_question")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;

	@ManyToOne
	@JoinColumn(name="id_user")
	private User user;
	
	@ManyToOne
	@JoinColumn(name="id_statut")
	private Statut statut;
	
	@OneToMany(targetEntity=QuestionChoixGeo.class, mappedBy="id")
	private List<QuestionChoixGeo> choixGeo = new ArrayList<>();
	
	private String code;

	private String libelle;

	private String description;

	private String image;
	
	private int forwards;

	@Column(name="date_creation")
	private Date dateCreation;

	@Column(name="date_modification")
	private Date dateModification;

	@Column(name="date_expiration")
	private Date dateExpiration;
	
	public Question() {
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public Statut getStatut() {
		return statut;
	}

	public void setStatut(Statut statut) {
		this.statut = statut;
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

	public String getImage() {
		return image;
	}

	public void setImage(String image) {
		this.image = image;
	}

	public int getForwards() {
		return forwards;
	}

	public void setForwards(int forwards) {
		this.forwards = forwards;
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

	public Date getDateExpiration() {
		return dateExpiration;
	}

	public void setDateExpiration(Date dateExpiration) {
		this.dateExpiration = dateExpiration;
	}

	public List<QuestionChoixGeo> getChoixGeo() {
		return choixGeo;
	}

	public void setChoixGeo(List<QuestionChoixGeo> choixGeo) {
		this.choixGeo = choixGeo;
	}
	
	

}