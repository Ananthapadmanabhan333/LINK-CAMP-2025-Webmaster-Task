import { Link } from "react-router-dom";

const Success = () => {
  return (
    <div className="register-page">
      <h1>Registration Successful 🎉</h1>
      <p>
        Thank you for registering for LINK CAMP 2025.
        We’ll contact you with further details.
      </p>

      <Link to="/" className="btn-primary">
        Back to Home
      </Link>
    </div>
  );
};

export default Success;
