from flask import Flask
import db
from routes.auth import auth_bp
from routes.overview import overview_bp
from routes.relatorios import relatorios_bp
from routes.lideres import lideres_bp
from routes.comandante import comandante_bp
from routes.cientista import cientista_bp
from routes.index import index_bp

app = Flask(__name__)
app.config['SECRET_KEY'] = '[hashgrandona]'

db.init_app(app)

app.register_blueprint(index_bp)
app.register_blueprint(auth_bp)
app.register_blueprint(overview_bp)
app.register_blueprint(relatorios_bp)
app.register_blueprint(lideres_bp)
app.register_blueprint(comandante_bp)
app.register_blueprint(cientista_bp)

if __name__ == '__main__':
    app.run(debug=True)
