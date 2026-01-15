const Schedule = () => {
  return (
    <section id="schedule" className="section gray">
      <h2>Program Schedule</h2>

      <p>
        LINK CAMP 2025 is structured as a two-day immersive program designed to
        balance learning, interaction, and practical exposure. Each day is
        carefully planned to ensure participants gain maximum value from the
        sessions.
      </p>

      <div className="schedule">
        <div className="card">
          <h3>Day 1 – Orientation & Foundations</h3>
          <p>
            The first day focuses on orientation, introduction to IEEE LINK, and
            foundational sessions on leadership, teamwork, and effective
            communication. Participants will engage in interactive discussions
            and ice-breaking activities.
          </p>
        </div>

        <div className="card">
          <h3>Day 2 – Skill Building & Collaboration</h3>
          <p>
            The second day emphasizes hands-on learning through workshops, group
            activities, and collaborative problem-solving tasks. The program
            concludes with reflections, feedback, and a closing ceremony.
          </p>
        </div>
      </div>
    </section>
  );
};

export default Schedule;
