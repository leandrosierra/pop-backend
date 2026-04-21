package com.lsi.server.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.QuestionMeeting;

@Repository
public interface QuestionMeetingRepository extends JpaRepository<QuestionMeeting, Long> {

	@Query("SELECT m FROM QuestionMeeting m where m.question.id = :questionId order by m.dateDebut asc")
	List<QuestionMeeting> findMeetingsByQuestionId(@Param("questionId") Long questionId);
}
