import Navbar from "../components/Navbar";
import Hero from "../components/Hero";
import About from "../components/About";
import Schedule from "../components/Schedule";
import CTA from "../components/CTA";
import Footer from "../components/Footer";

function Home() {
  return (
    <>
      <Navbar />
      <Hero />
      <About />
      <Schedule />
      <CTA />
      <Footer />
    </>
  );
}

export default Home;
