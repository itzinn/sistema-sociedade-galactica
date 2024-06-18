import db

def call_alterar_nome_faccao(novo_nome):
    conn = db.get_db()
    cur = conn.cursor()
    try:
        cur.callproc('alterar_nome_faccao', [novo_nome])
        conn.commit()
        flash('Nome da facção alterado com sucesso!', 'success')
    except Exception as e:
        conn.rollback()
        flash(f'Erro ao alterar nome da facção: {e}', 'danger')
    finally:
        cur.close()
        conn.close()
