defmodule ClinicflowWeb.PageControllerTest do
  use ClinicflowWeb.ConnCase

  describe "GET /" do
    test "renders the premium landing page", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # Check for key landing page elements
      assert response =~ "ClinicFlow"
      assert response =~ "waiting room"
      assert response =~ "chaos"
      assert response =~ "Start Free Trial"
    end

    test "contains value proposition sections", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # Social proof metrics
      assert response =~ "50%"
      assert response =~ "Wait Time Reduction"

      # Features section
      assert response =~ "Reception Queue"
      assert response =~ "Emergency"
    end

    test "contains pricing section", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      assert response =~ "Starter"
      assert response =~ "Professional"
      assert response =~ "Enterprise"
    end
  end

  describe "GET /about" do
    test "renders the about page", %{conn: conn} do
      conn = get(conn, ~p"/about")
      response = html_response(conn, 200)

      # Check for key about page elements
      assert response =~ "ClinicFlow"
      assert response =~ "Our Mission"
      assert response =~ "Our Core"
    end

    test "contains team section", %{conn: conn} do
      conn = get(conn, ~p"/about")
      response = html_response(conn, 200)

      # Team section
      assert response =~ "Meet Our"
      assert response =~ "Team"
      assert response =~ "CEO"
    end

    test "contains values section", %{conn: conn} do
      conn = get(conn, ~p"/about")
      response = html_response(conn, 200)

      assert response =~ "Values"
      assert response =~ "Simplicity"
      assert response =~ "Trust"
    end
  end

  describe "GET /contact" do
    test "renders the contact page", %{conn: conn} do
      conn = get(conn, ~p"/contact")
      response = html_response(conn, 200)

      # Check for key contact page elements
      assert response =~ "ClinicFlow"
      assert response =~ "Get in Touch"
      assert response =~ "Send us a Message"
    end

    test "contains contact form", %{conn: conn} do
      conn = get(conn, ~p"/contact")
      response = html_response(conn, 200)

      # Form fields
      assert response =~ "First Name"
      assert response =~ "Email Address"
      assert response =~ "Message"
      assert response =~ "Send Message"
    end

    test "contains contact information", %{conn: conn} do
      conn = get(conn, ~p"/contact")
      response = html_response(conn, 200)

      # Contact methods
      assert response =~ "Email Us"
      assert response =~ "Call Us"
      assert response =~ "Visit Us"
    end

    test "contains FAQ section", %{conn: conn} do
      conn = get(conn, ~p"/contact")
      response = html_response(conn, 200)

      assert response =~ "Frequently Asked Questions"
      assert response =~ "HIPAA compliant"
      assert response =~ "free trial"
    end
  end
end
