import { Link } from "react-router-dom";

const Hero = () => {
  return (
    <section className="hero">
      <h1>LINK CAMP 2025</h1>
      <p>
        A premier IEEE student development camp focused on leadership,
        technology, and collaboration.
      </p>
      <Link to="/register" className="btn-primary">
        Register Now
      </Link>
    </section>
  );
};

export default Hero;
