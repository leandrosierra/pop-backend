package com.lsi.server.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name="STATUT_REF")
public class Statut  {

	@Id
	@Column(name="id_statut")
	private int idStatut;

	private String code;

	private String libelle;

	public Statut() {
	}

	public int getIdStatut() {
		return idStatut;
	}

	public void setIdStatut(int idStatut) {
		this.idStatut = idStatut;
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

}