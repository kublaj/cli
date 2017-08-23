require "spec_helper"

describe Sem::CLI do

  describe "#login" do
    before { allow(Sem::Configuration).to receive(:export_auth_token) }

    context "when the auth token is valid" do
      before { allow(Sem::Configuration).to receive(:valid_auth_token?).and_return(true) }

      it "sets the auth token" do
        expect(Sem::Configuration).to receive(:export_auth_token).with("123456")

        sem_run("login --auth_token 123456")
      end

      it "displays a success message" do
        stdout, stderr = sem_run("login --auth_token 123456")

        msg = [
          "Your credentials have been saved to #{Sem::Configuration::CREDENTIALS_PATH}."
        ]

        expect(stdout.strip).to eq(msg.join("\n"))
        expect(stderr).to eq("")
      end
    end

    context "invalid auth token" do
      before { allow(Sem::Configuration).to receive(:valid_auth_token?).and_return(false) }

      it "writes an error to the output" do
        _stdout, stderr = sem_run("login --auth_token 123456")

        msg = [
          "[ERROR] Token is invalid!"
        ]

        expect(stderr.strip).to eq(msg.join("\n"))
      end

      it "does not set the auth token" do
        expect(Sem::Configuration).to_not receive(:export_auth_token).with("123456")

        sem_run("login --auth_token 123456")
      end
    end
  end

end