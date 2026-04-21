package com.lsi.server.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.QuestionComment;

@Repository
public interface QuestionCommentRepository extends JpaRepository<QuestionComment, Long> {

	@Query("SELECT c FROM QuestionComment c where c.question.id = :questionId order by c.dateCreation asc")
	List<QuestionComment> findCommentsByQuestionId(@Param("questionId") Long questionId);
}
