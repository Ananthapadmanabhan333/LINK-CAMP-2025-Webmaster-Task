import { Link } from "react-router-dom";

const CTA = () => {
  return (
    <section className="cta">
      <h2>Be a Part of LINK CAMP 2025</h2>
      <p>
        Take the next step in your IEEE journey by joining LINK CAMP 2025.
        Register now to enhance your skills, expand your network, and gain
        valuable leadership experience.
      </p>
      <Link to="/register" className="btn-primary">
        Register Now
      </Link>
    </section>
  );
};

export default CTA;
