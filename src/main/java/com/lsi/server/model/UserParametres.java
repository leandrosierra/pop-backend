package com.lsi.server.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name="USER_PARAMETRES")
public class UserParametres  {

	@Id
	@Column(name="id_parametre")
	private int idParametre;
	
	@OneToMany( targetEntity=Langues.class, mappedBy="idParametre" )
	private List<Langues> langues = new ArrayList<>();
	
	public List<Langues> getLangues() {
		return langues;
	}

	public void setLangues(List<Langues> langues) {
		this.langues = langues;
	}

	public int getIdParametre() {
		return idParametre;
	}

	public void setIdParametre(int idParametre) {
		this.idParametre = idParametre;
	}

	

}