CREATE TABLE `vyntra_restrictedzones` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `title` longtext NOT NULL,
    `description` longtext NOT NULL,
    `x` longtext NOT NULL,
    `y` longtext NOT NULL,
    `z` longtext NOT NULL,
    `radius` longtext NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;