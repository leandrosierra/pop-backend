package com.lsi.server.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.geo.QuestionChoixGeo;

@Repository
public interface QuestionsChoixGeoRepository extends JpaRepository<QuestionChoixGeo, Long> {
	
}
