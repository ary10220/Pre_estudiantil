const express = require('express');
const usuarios = require('./usuarios');
const sesiones = require('../../comun/sesiones');
const recuperaciones = require('./recuperaciones');
const { estaVacio, correoValido } = require('./validaciones');

const router = express.Router();

router.post('/registro', async (req, res) => {
  const { nombre, correo, contrasena } = req.body || {};

  if (estaVacio(nombre) || estaVacio(correo) || estaVacio(contrasena)) {
    return res.status(400).json({ error: 'Completá todos los campos' });
  }
  if (!correoValido(correo)) {
    return res.status(400).json({ error: 'Escribí un correo válido' });
  }
  if (contrasena.length < 6) {
    return res.status(400).json({ error: 'Mínimo 6 caracteres' });
  }

  const existente = await usuarios.buscarPorCorreo(correo);
  if (existente) {
    return res.status(409).json({ error: 'Ese correo ya tiene una cuenta' });
  }

  const usuario = await usuarios.crearUsuario(nombre, correo, contrasena);
  res.status(201).json({ usuario });
});

router.post('/login', async (req, res) => {
  const { correo, contrasena } = req.body || {};

  if (estaVacio(correo) || estaVacio(contrasena)) {
    return res.status(400).json({ error: 'Completá todos los campos' });
  }

  const usuario = await usuarios.buscarPorCorreo(correo);
  const coincide = usuario && await usuarios.contrasenaCorrecta(contrasena, usuario.contrasena_hash);
  if (!coincide) {
    return res.status(401).json({ error: 'El correo o la contraseña no coinciden' });
  }

  const { token } = await sesiones.crearSesion(usuario.id);
  res.json({
    token,
    usuario: { id: usuario.id, nombre: usuario.nombre, correo: usuario.correo },
  });
});

router.post('/recuperar', async (req, res) => {
  const { correo } = req.body || {};

  if (estaVacio(correo)) {
    return res.status(400).json({ error: 'Completá todos los campos' });
  }

  const usuario = await usuarios.buscarPorCorreo(correo);
  if (!usuario) {
    return res.status(404).json({ error: 'No hay ninguna cuenta con ese correo' });
  }

  const codigo = await recuperaciones.generarCodigo(usuario.id);
  res.json({ codigo });
});

router.post('/cambiar-contrasena', async (req, res) => {
  const { correo, codigo, nueva } = req.body || {};

  if (estaVacio(correo) || estaVacio(codigo) || estaVacio(nueva)) {
    return res.status(400).json({ error: 'Completá todos los campos' });
  }
  if (nueva.length < 6) {
    return res.status(400).json({ error: 'Mínimo 6 caracteres' });
  }

  const usuario = await usuarios.buscarPorCorreo(correo);
  if (!usuario) {
    return res.status(400).json({ error: 'El código no coincide' });
  }

  const verificacion = await recuperaciones.verificarCodigo(usuario.id, codigo.trim());
  if (verificacion.estado === 'no_coincide') {
    return res.status(400).json({ error: 'El código no coincide' });
  }
  if (verificacion.estado === 'vencido') {
    return res.status(400).json({ error: 'El código venció' });
  }

  await usuarios.cambiarContrasena(usuario.id, nueva);
  await recuperaciones.marcarUsado(verificacion.id);
  await sesiones.borrarSesionesDeUsuario(usuario.id);
  res.json({ mensaje: 'Contraseña actualizada' });
});

module.exports = router;
