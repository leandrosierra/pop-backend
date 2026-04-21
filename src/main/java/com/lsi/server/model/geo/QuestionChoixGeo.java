package com.lsi.server.model.geo;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import com.lsi.server.model.Question;
import com.lsi.server.model.UserAdresse;

@Entity
@Table(name="QUESTION_CHOIX_GEO")
public class QuestionChoixGeo  {

	@Id
	@Column(name="id_question_choix_geo")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;
	
	@ManyToOne
	@JoinColumn(name="id_question")
	private Question question;
	
	@ManyToOne(cascade = CascadeType.MERGE)
	@JoinColumn(name="id_pays")
	private Pays pays;
	
	@ManyToOne
	@JoinColumn(name="id_dept")
	private Dept dept;
	
	@ManyToOne
	@JoinColumn(name="id_ville")
	private Ville ville;

	

	public Question getQuestion() {
		return question;
	}

	public void setQuestion(Question question) {
		this.question = question;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
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