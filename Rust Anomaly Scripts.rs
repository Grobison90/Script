
  /// Converts mean anomaly into eccentric anomaly
///
/// # Arguments
///
/// * `anm_mean`:Mean anomaly. Units: (rad) or (deg)
/// * `e`:The eccentricity of the astronomical object's orbit. Dimensionless
/// * `as_degrees`:Interprets input and returns output in (deg) if `true` or (rad) if `false`
///
/// # Returns
///
/// * `anm_ecc`:Eccentric anomaly. Units: (rad) or (deg)
///
/// # Examples
/// ```rust
/// use rastro::orbits::anomaly_mean_to_eccentric;
/// let e = anomaly_mean_to_eccentric(90.0, 0.001, true).unwrap();
/// ```
pub fn anomaly_mean_to_eccentric(anm_mean: f64, e: f64, as_degrees: bool) -> Result<f64, String> {
    // Ensure anm_mean is in radians regardless of input
    let anm_mean = if as_degrees == true {
        anm_mean * PI / 180.0
    } else {
        anm_mean
    };

    // Set constants of iteration
    let max_iter = 10;
    let eps = 100.0 * f64::EPSILON; // Convergence with respect to data-type precision

    // Initialize starting iteration values
    let anm_mean = anm_mean % (2.0 * PI);
    let mut anm_ecc = if e < 0.8 { anm_mean } else { PI };

    let mut f = anm_ecc - e * anm_ecc.sin() - anm_mean;
    let mut i = 0;

    // Iterate until convergence
    while f.abs() > eps {
        f = anm_ecc - e * anm_ecc.sin() - anm_mean;
        anm_ecc = anm_ecc - f / (1.0 - e * anm_ecc.cos());

        i += 1;
        if i > max_iter {
            return Err(format!(
                "Reached maximum number of iterations ({}) before convergence for (M: {}, e: {}).",
                max_iter, anm_mean, e
            ));
        }
    }

    // Convert output to desired angular format
    if as_degrees == true {
        Ok(anm_ecc * 180.0 / PI)
    } else {
        Ok(anm_ecc)
    }
}

/// Converts true anomaly into eccentric anomaly
///
/// # Arguments
///
/// * `anm_true`:true anomaly. Units: (rad) or (deg)
/// * `e`:The eccentricity of the astronomical object's orbit. Dimensionless
/// * `as_degrees`:Interprets input and returns output in (deg) if `true` or (rad) if `false`
///
/// # Returns
///
/// * `anm_ecc`:Eccentric anomaly. Units: (rad) or (deg)
///
/// # Examples
/// ```rust
/// use rastro::orbits::anomaly_true_to_eccentric;
/// let anm_ecc = anomaly_true_to_eccentric(15.0, 0.001, true);
/// ```
///
/// # Reference
/// 1. D. Vallado, *Fundamentals of Astrodynamics and Applications (4th Ed.)*, pp. 47, eq. 2-9, 2010.
pub fn anomaly_true_to_eccentric(anm_true: f64, e: f64, as_degrees: bool) -> f64 {
    // Ensure anm_true is in radians regardless of input
    let anm_true = if as_degrees == true {
        anm_true * PI / 180.0
    } else {
        anm_true
    };

    let anm_ecc = (anm_true.sin() * (1.0 - e.powi(2)).sqrt()).atan2(anm_true.cos() + e);

    if as_degrees == true {
        anm_ecc * 180.0 / PI
    } else {
        anm_ecc
    }
}

/// Converts eccentric anomaly into true anomaly
///
/// # Arguments
///
/// * `anm_ecc`:Eccentric anomaly. Units: (rad) or (deg)
/// * `e`:The eccentricity of the astronomical object's orbit. Dimensionless
/// * `as_degrees`:Interprets input and returns output in (deg) if `true` or (rad) if `false`
///
/// # Returns
///
/// * `anm_true`:true anomaly. Units: (rad) or (deg)
///
/// # Examples
/// ```rust
/// use rastro::orbits::anomaly_eccentric_to_true;
/// let ecc_anm = anomaly_eccentric_to_true(15.0, 0.001, true);
/// ```
///
/// # Reference
/// 1. D. Vallado, *Fundamentals of Astrodynamics and Applications (4th Ed.)*, pp. 47, eq. 2-9, 2010.
pub fn anomaly_eccentric_to_true(anm_ecc: f64, e: f64, as_degrees: bool) -> f64 {
    // Ensure anm_ecc is in radians regardless of input
    let anm_ecc = if as_degrees == true {
        anm_ecc * PI / 180.0
    } else {
        anm_ecc
    };

    let anm_true = (anm_ecc.sin() * (1.0 - e.powi(2)).sqrt()).atan2(anm_ecc.cos() - e);

    if as_degrees == true {
        anm_true * 180.0 / PI
    } else {
        anm_true
    }
}

/// Converts true anomaly into mean anomaly.
///
/// # Arguments
///
/// * `anm_true`:True anomaly. Units: (rad) or (deg)
/// * `e`:The eccentricity of the astronomical object's orbit. Dimensionless
/// * `as_degrees`:Interprets input and returns output in (deg) if `true` or (rad) if `false`
///
/// # Returns
///
/// * `anm_mean`:Mean anomaly. Units: (rad) or (deg)
///
/// # Examples
/// ```rust
/// use rastro::orbits::anomaly_true_to_mean;
/// let anm_mean = anomaly_true_to_mean(90.0, 0.001, true);
/// ```
///
/// # References:
///  1. O. Montenbruck, and E. Gill, *Satellite Orbits: Models, Methods and
///  Applications*, 2012.
pub fn anomaly_true_to_mean(anm_true: f64, e: f64, as_degrees: bool) -> f64 {
    anomaly_eccentric_to_mean(
        anomaly_true_to_eccentric(anm_true, e, as_degrees),
        e,
        as_degrees,
    )
}

/// Converts mean anomaly into true anomaly
///
/// # Arguments
///
/// * `anm_mean`:Mean anomaly. Units: (rad) or (deg)
/// * `e`:The eccentricity of the astronomical object's orbit. Dimensionless
/// * `as_degrees`:Interprets input and returns output in (deg) if `true` or (rad) if `false`
///
/// # Returns
///
/// * `anm_true`:True anomaly. Units: (rad) or (deg)
///
/// # Examples
/// ```rust
/// use rastro::orbits::anomaly_mean_to_true;
/// let e = anomaly_mean_to_true(90.0, 0.001, true).unwrap();
/// ```
pub fn anomaly_mean_to_true(anm_mean: f64, e: f64, as_degrees: bool) -> Result<f64, String> {
    // Ensure anm_mean is in radians regardless of input
    let anm_mean = if as_degrees == true {
        anm_mean * PI / 180.0
    } else {
        anm_mean
    };

    // Set constants of iteration
    let max_iter = 10;
    let eps = 100.0 * f64::EPSILON; // Convergence with respect to data-type precision

    // Initialize starting iteration values
    let anm_mean = anm_mean % (2.0 * PI);
    let mut anm_ecc = if e < 0.8 { anm_mean } else { PI };

    let mut f = anm_ecc - e * anm_ecc.sin() - anm_mean;
    let mut i = 0;

    // Iterate until convergence
    while f.abs() > eps {
        f = anm_ecc - e * anm_ecc.sin() - anm_mean;
        anm_ecc = anm_ecc - f / (1.0 - e * anm_ecc.cos());

        i += 1;
        if i > max_iter {
            return Err(format!(
                "Reached maximum number of iterations ({}) before convergence for (M: {}, e: {}).",
                max_iter, anm_mean, e
            ));
        }
    }

    // Convert output to desired angular format
    if as_degrees == true {
        anm_ecc = anm_ecc * 180.0 / PI;
    }

    // Finish conversion from eccentric to true anomaly
    Ok(anomaly_eccentric_to_true(anm_ecc, e, as_degrees))