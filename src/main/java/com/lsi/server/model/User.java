package com.lsi.server.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name="USERS")
public class User {
	
	@Id
	@Column(name="id_user")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;

	private String login;

	private String nom;

	@JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
	private String password;

	private String prenom;
	
	private String email;

	private boolean actif;

	@OneToMany( targetEntity=UserAdresse.class, mappedBy="idUser", cascade = CascadeType.MERGE)
	private List<UserAdresse> adresses = new ArrayList<>();
	
	@OneToMany( targetEntity=Interets.class, mappedBy="idUser" )
	private List<Interets> interets = new ArrayList<>();

	@OneToMany( targetEntity=UserChoixGeo.class, mappedBy="idUser")
	private List<UserChoixGeo> choixGeo = new ArrayList<>();
	
	@ManyToOne(cascade = CascadeType.MERGE)
	@JoinColumn(name="id_role")
	private Role role;
	
	@ManyToOne(cascade = CascadeType.MERGE)
	@JoinColumn(name="id_parametre")
	private UserParametres parametres;

	@Column(name="date_creation")
	private Date dateCreation;

	@Column(name="date_modification")
	private Date dateModification;

	@Column(name="date_suppression")
	private Date dateSuppression;
	
	public User() {
	}

	public long getId() {
		return this.id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public Date getDateCreation() {
		return this.dateCreation;
	}

	public void setDateCreation(Date dateCreation) {
		this.dateCreation = dateCreation;
	}

	public Date getDateModification() {
		return this.dateModification;
	}

	public void setDateModification(Date dateModification) {
		this.dateModification = dateModification;
	}

	public Date getDateSuppression() {
		return this.dateSuppression;
	}

	public void setDateSuppression(Date dateSuppression) {
		this.dateSuppression = dateSuppression;
	}

	public String getLogin() {
		return this.login;
	}

	public void setLogin(String login) {
		this.login = login;
	}

	public String getNom() {
		return this.nom;
	}

	public void setNom(String nom) {
		this.nom = nom;
	}

	public String getPassword() {
		return this.password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getPrenom() {
		return this.prenom;
	}

	public void setPrenom(String prenom) {
		this.prenom = prenom;
	}

	public boolean isActif() {
		return actif;
	}

	public void setActif(boolean actif) {
		this.actif = actif;
	}

	public Role getRole() {
		return this.role;
	}

	public void setPopRole(Role role) {
		this.role = role;
	}
	
	public UserParametres getParametres() {
		return parametres;
	}

	public void setParametres(UserParametres parametres) {
		this.parametres = parametres;
	}
	
	public List<UserAdresse> getAdresses() {
		return adresses;
	}

	public void setAdresses(List<UserAdresse> adresses) {
		this.adresses = adresses;
	}

	public void setRole(Role role) {
		this.role = role;
	}

	public List<Interets> getInterets() {
		return interets;
	}

	public void setInterets(List<Interets> interets) {
		this.interets = interets;
	}

	public List<UserChoixGeo> getChoixGeo() {
		return choixGeo;
	}

	public void setChoixGeo(List<UserChoixGeo> choixGeo) {
		this.choixGeo = choixGeo;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}
	
	

}
