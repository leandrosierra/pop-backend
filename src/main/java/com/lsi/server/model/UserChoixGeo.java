package com.lsi.server.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.lsi.server.model.geo.Dept;
import com.lsi.server.model.geo.Pays;
import com.lsi.server.model.geo.Ville;

@Entity
@Table(name="USER_CHOIX_GEO")
public class UserChoixGeo  {

	@Id
	@Column(name="id_user")
	@JsonIgnore
	private long idUser;
	
	@ManyToOne
	@JoinColumn(name="id_pays")
	private Pays pays;
	
	@ManyToOne
	@JoinColumn(name="id_dept")
	private Dept dept;
	
	@ManyToOne
	@JoinColumn(name="id_ville")
	private Ville ville;

	public long getIdUser() {
		return idUser;
	}

	public void setIdUser(long idUser) {
		this.idUser = idUser;
	}

	public Pays getPays() {
		return pays;
	}

	public void setPays(Pays pays) {
		this.pays = pays;
	}

	public Dept getDept() {
		return dept;
	}

	public void setDept(Dept dept) {
		this.dept = dept;
	}

	public Ville getVille() {
		return ville;
	}

	public void setVille(Ville ville) {
		this.ville = ville;
	}
	
	

}