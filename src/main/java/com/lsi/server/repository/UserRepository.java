package com.lsi.server.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.Question;
import com.lsi.server.model.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

	@Query("SELECT u FROM User u where u.login = :login") 
    Optional<User> findUserByLogin(@Param("login") String login);
	
	@Query("SELECT q FROM Question q where q.user.id = :userId") 
    List<Question> findQuestionByUser(@Param("userId") Long userId);
	
	@Query("SELECT q FROM Question q where q.user.id = :userId") 
    List<Question> findQuestionForUser(@Param("userId") Long userId);
	
}
