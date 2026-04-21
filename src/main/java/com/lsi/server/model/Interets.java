package com.lsi.server.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name="USER_INTERETS")
public class Interets  {

	@Id
	@JsonIgnore
	@Column(name="id_user")
	private int idUser;
	
	@ManyToOne
	@JoinColumn(name="id_interet")
	private Interet interet;
	
	private int priorite;
	
	public Interet getInteret() {
		return interet;
	}

	public void setInteret(Interet interet) {
		this.interet = interet;
	}

	public int getIdUser() {
		return idUser;
	}

	public void setIdUser(int idUser) {
		this.idUser = idUser;
	}

	public int getPriorite() {
		return priorite;
	}

	public void setPriorite(int priorite) {
		this.priorite = priorite;
	}
	
}