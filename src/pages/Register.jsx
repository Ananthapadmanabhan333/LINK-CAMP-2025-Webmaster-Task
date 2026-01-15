const Register = () => {
  const handleSubmit = (e) => {
    e.preventDefault();
    window.location.href = "https://forms.gle/6A3kNqmxWAQvFbAF6";
  };

  return (
    <div className="register-page">
      <h1>LINK CAMP 2025 Registration</h1>
      <p>Secure your spot at LINK CAMP 2025.</p>

      <form className="register-form" onSubmit={handleSubmit}>
        <input type="text" placeholder="Full Name" required />
        <input type="email" placeholder="Email Address" required />
        <input type="text" placeholder="College / Institution" required />

        <select required>
          <option value="">IEEE Membership Status</option>
          <option>IEEE Member</option>
          <option>Non-Member</option>
        </select>

        <button type="submit">Proceed to Final Registration</button>
      </form>
    </div>
  );
};

export default Register;
