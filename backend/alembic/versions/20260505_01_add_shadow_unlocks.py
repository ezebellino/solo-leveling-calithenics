"""Add shadow unlocks module table."""

from alembic import op
import sqlalchemy as sa


revision = "20260505_01"
down_revision = "20260504_01"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "shadow_unlocks",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("code", sa.String(length=80), nullable=False),
        sa.Column("obtained_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "code", name="uq_shadow_unlock_user_code"),
    )


def downgrade() -> None:
    op.drop_table("shadow_unlocks")
