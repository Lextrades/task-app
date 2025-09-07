const Footer = () => {
  return (
    <footer className="bg-transparent text-white py-4">
      <div className="container mx-auto px-4 text-center text-sm">
        Task App by{" "}
        <a
          href="https://www.nextlevel.trading"
          target="_blank"
          rel="noopener noreferrer"
          className="underline"
        >
          NextLevel
        </a>{" "}
        🛠️ View on{" "}
        <a
          href="https://github.com/Lextrades/task-app"
          target="_blank"
          rel="noopener noreferrer"
          className="underline"
        >
          GitHub
        </a>
      </div>
    </footer>
  );
};

export default Footer;
