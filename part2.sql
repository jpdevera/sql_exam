/**
* PLEASE make sure that all tables and columns exist 
* such as (trn_teacher, trn_teacher_role, trn_time_table, trn_evaluation)
* this is based on the given pdf file ( MySQLExam.pdf )
* Execute the following
* 
* USE <your_db_name>; 
*/


/* 1. 
	Write a query to display the ff columns ID (should start
	with T + 11 digits of trn_teacher.id with leading zeros like
	'T00000088424'), Nickname, Status and Roles (like
	Trainer/Assessor/Staff) using table trn_teacher and
	trn_teacher_role. 
*/
SELECT 
	CONCAT('T',LPAD(A.id, 11, 0)) ID,
    A.nickname Nickname,
    CASE 
		WHEN A.status = 0 THEN 'Discontinued'
        WHEN A.status = 1 THEN 'Active'
        WHEN A.status = 2 THEN 'Deactivated'
    END `Status`,
	GROUP_CONCAT(
		CASE 
		WHEN B.role = 1 THEN 'Trainer'
        WHEN B.role = 2 THEN 'Assessor'
        WHEN B.role = 3 THEN 'Staff'
    END SEPARATOR '/') `Roles`
FROM trn_teacher A
JOIN trn_teacher_role B ON A.id=B.teacher_id
GROUP BY A.id
ORDER BY A.nickname;

/*2. 
	Write a query to display the ff columns ID (from teacher.id),
	Nickname, Open (total open slots from trn_teacher_time_table),
	Reserved (total reserved slots from trn_teacher_time_table),
	Taught (total taught from trn_evaluation) and NoShow (total
	no_show from trn_evaluation) using all tables above. Should
	show only those who are active (trn_teacher.status = 1 or 2)
	and those who have both Trainer and Assessor role
*/
SELECT 
	A.id ID,
    A.nickname Nickname,
    IFNULL(C.`Open`,0) `Open`,
    IFNULL(D.Reserved,0) Reserved,
    IFNULL(E.Taught,0) Taught,
	IFNULL(F.NoShow,0) NoShow
FROM trn_teacher A
JOIN trn_teacher_role B ON A.id=B.teacher_id
LEFT JOIN (
	SELECT teacher_id, COUNT(teacher_id) `Open`
	FROM trn_time_table 
	WHERE status=1
	GROUP BY teacher_id
)C ON A.id=C.teacher_id
LEFT JOIN (
	SELECT teacher_id, COUNT(teacher_id) Reserved
	FROM trn_time_table 
	WHERE status=3
	GROUP BY teacher_id
)D ON A.id=D.teacher_id
LEFT JOIN (
	SELECT teacher_id, COUNT(teacher_id) Taught
	FROM trn_evaluation 
	WHERE result=1
	GROUP BY teacher_id
)E ON A.id=E.teacher_id
LEFT JOIN (
	SELECT teacher_id, COUNT(teacher_id) NoShow
	FROM trn_evaluation 
	WHERE result=2
	GROUP BY teacher_id
)F ON A.id=F.teacher_id
WHERE A.status IN (1,2) 
	AND B.role IN (1,2)
GROUP BY ID
ORDER BY A.nickname;