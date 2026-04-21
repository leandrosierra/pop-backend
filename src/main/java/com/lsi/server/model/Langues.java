package com.lsi.server.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name="USER_PARAMETRES_LANGUE")
public class Langues  {

	@Id
	@Column(name="id_parametre")
	private int idParametre;
	
	@ManyToOne
	@JoinColumn(name="id_langue")
	private Langue langue;
	
	public Langue getLangue() {
		return langue;
	}

	public void setLangue(Langue langue) {
		this.langue = langue;
	}

	public int getIdParametre() {
		return idParametre;
	}

	public void setIdParametre(int idParametre) {
		this.idParametre = idParametre;
	}

	

}