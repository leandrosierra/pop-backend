package com.lsi.server.model.geo;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.lsi.server.model.Langue;

@Entity
@Table(name="DEPT_REF")
public class Dept  {

	@Id
	@Column(name="id_dept")
	@JsonIgnore
	private int idDept;

	private String code;

	private String libelle;
	
	@ManyToOne
	@JoinColumn(name="id_pays")
	private Pays pays;

	public Pays getPays() {
		return pays;
	}

	public void setPays(Pays pays) {
		this.pays = pays;
	}

	public int getIdDept() {
		return idDept;
	}

	public void setIdDept(int idDept) {
		this.idDept = idDept;
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