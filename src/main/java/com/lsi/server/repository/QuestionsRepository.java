package com.lsi.server.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.Question;

@Repository
public interface QuestionsRepository extends JpaRepository<Question, Long> {

	@Query("SELECT q FROM Question q where q.statut.code = :code")
	List<Question> findQuestionsByStatutCode(@Param("code") String code);
	
}
