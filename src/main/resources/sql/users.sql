CREATE TABLE Users (
  id bigint(20) NOT NULL,
  active int(11) NOT NULL,
  username varchar(10) NOT NULL UNIQUE,
  password varchar(100) DEFAULT NULL,
  authority varchar(100) NOT NULL,
  firstName varchar(100) NOT NULL,
  lastName varchar(100) NOT NULL,
  email varchar(100) DEFAULT NULL,
  state varchar(30) DEFAULT NULL,
  branch varchar(50) DEFAULT NULL,
  registerDate date DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO jae.Users (id, active, username, password, authority, firstName, lastName, email, state, branch, registerDate) VALUES (1,0,'js101','111','ROLE_Administrator','Jinhyung','Seo','jin@test.com','1','13','2024-03-31');
