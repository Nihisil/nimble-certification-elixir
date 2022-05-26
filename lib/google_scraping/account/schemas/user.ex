defmodule GoogleScraping.Accounts.Schemas.User do
  use Ecto.Schema

  import Ecto.Changeset
  import GoogleScrapingWeb.Gettext

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.
  """
  def registration_changeset(user \\ %__MODULE__{}, attrs \\ %{}) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_email()
    |> validate_password()
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0,
      do: Bcrypt.verify_pass(password, hashed_password)

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
      message: gettext("must have the @ sign and no spaces")
    )
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, GoogleScraping.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> maybe_hash_password()
  end

  defp maybe_hash_password(
         %Ecto.Changeset{changes: %{password: password}, valid?: true} = changeset
       ) do
    changeset
    # If using Bcrypt, then further validate it is at most 72 bytes long
    |> validate_length(:password, max: 72, count: :bytes)
    |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
    |> delete_change(:password)
  end

  defp maybe_hash_password(changeset), do: changeset
end
