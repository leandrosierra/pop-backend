package com.lsi.server.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name="USER_INTERETS_REF")
public class Interet  {

	@Id
	@JsonIgnore
	@Column(name="id_interet")
	private int idInteret;

	private String code;

	private String libelle;

	public Interet() {
	}

	public int getIdInteret() {
		return idInteret;
	}

	public void setIdInteret(int idInteret) {
		this.idInteret = idInteret;
	}

	public String getCode() {
		return this.code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getLibelle() {
		return this.libelle;
	}

	public void setLibelle(String libelle) {
		this.libelle = libelle;
	}

}