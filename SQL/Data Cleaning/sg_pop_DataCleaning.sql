--removing rows that are of higher level of aggregation in the level_1 column which do not contain either gender information 
--removed rows are:Other Ethnic Groups (Total),Total Chinese,Total Indians,Total Residents,Total Malays
DELETE 
FROM sg_pop 
WHERE NOT(level_1 LIKE '%Male%'
		OR level_2 LIKE '%Female%')

--adding 'gender','ethnicity' and 'age_group' column for data to be extracted from 'level_1' and 'level_2' column
ALTER TABLE sg_pop
ADD gender varchar(255), 
	ethnicity varchar(255),
	age_group varchar(255),
	number_of_residents int

--assigning the corresponding gender values into the new 'gender' column from 'level_1' column
UPDATE sg_pop
SET gender=
	CASE 
		WHEN level_1 like '%Female%' THEN 'Female'
		WHEN level_1 like '%Male%' THEN 'Male'
		END

--assigning the corresponding ethnicity values into the new 'ethnicity' column from 'level_1' column
UPDATE sg_pop
SET ethnicity=
	CASE 
		WHEN level_1 like '%Malays' THEN 'Malay'
		WHEN level_1 like '%Chinese' THEN 'Chinese'
		WHEN level_1 like '%Indians' THEN 'Indian'
		WHEN level_1 like 'Other%' THEN 'Others'
		END

--removing redundant rows in level_2 as these rows contain repeated values
DELETE 
FROM sg_pop 
WHERE level_2 LIKE '65 Years & Over'
		OR level_2 LIKE '70 Years & Over'
		OR level_2 LIKE '75 Years & Over'
		OR level_2 LIKE '80 Years & Over'
		OR level_2 LIKE '85 Years & Over'

--assigning the corresponding age range values into the new 'age_group' column from 'level_2' column
--removing unnecessary strings 'Years' and 'Years & Over'as column name change has given clarity to new values
UPDATE sg_pop
SET age_group=
	CASE 
		WHEN level_2 LIKE '%& Over' THEN PARSENAME(REPLACE(level_2, ' Years & Over', '+'),1)
		ELSE PARSENAME(REPLACE(level_2, 'Years', ''),1)
	END

--assigning the corresponding numeric values into the new 'number_of_residenrs' column from 'value' column
UPDATE sg_pop
SET number_of_residents = 
	CASE
		when value>0 THEN value
		ELSE 0
	END

--dropping unused columns 
ALTER TABLE sg_pop
DROP COLUMN level_1, level_2, value
