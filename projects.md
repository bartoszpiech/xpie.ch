---
title: projects
---

<div class="project">
  <h3><a href="https://github.com/yourhandle/project-one">reverse engineering of a certain cad program</a></h3>
  <p>reverse engineered a woodworking cad program that is still actively maintained to this day. analysed the binary with ghidra and x64dbg, patched the license checks and injected a custom dll to bypass protection — works across versions.</p>
  <p class="tags">x64dbg · ghidra · dll injection · win32 · 03/2026</p>
</div>

<div class="project">
  <h3><a href="https://github.com/yourhandle/project-two">reverse engineering of a saas license</a></h3>
  <p>reversed a java spring saas backend to understand its license mechanism. the xml licenses were obfuscated with a custom xor-based encryption scheme. deconstructed the algorithm and wrote a standalone python license generator that produces valid licenses.</p>
  <p class="tags">java spring · python · license gen · 02/2026</p>
</div>

<div class="project">
  <h3><a href="https://github.com/bartoszpiech/baybot">baybot, the mmorpg gameplay automation bot</a></h3>
  <pre class="ascii-logo">               __             __        __
      / /  ___ ___ __/ /  ___  / /_
     / _ \/ _ `/ // / _ \/ _ \/ __/
    /_.__/\_,_/\_, /_.__/\___/\__/  v0.1
              /___/</pre>
  <p>built a gameplay automation bot for an mmorpg in python. used npcap and packet sniffing to read game state directly from network traffic rather than screen scraping, enabling reliable automation of in-game actions without relying on visual detection.</p>
  <p class="tags">python · npcap · packet sniffing · wireshark · 02/2025</p>
</div>

<div class="project">
  <h3><a href="https://github.com/yourhandle/project-three">packet sniffing an mmorpg market</a></h3>
  <p>analysed network traffic of an old polish mmorpg to extract real-time market and trading data. used wireshark with ip filtering to isolate game server packets, identified the market protocol structure, and built a parser to decode item listings and prices — enabling automated price tracking.</p>
  <p class="tags">python · wireshark · packet sniffing · protocol analysis · 01/2025</p>
</div>

<div class="project">
  <h3>shopper — product price & availability tracker</h3>
  <p>full stack web application that monitored product availability and prices across online stores, notifying users via email when items changed status. built with svelte on the frontend, golang and python on the backend, and mysql for storage.</p>
  <p class="tags">svelte · golang · python · mysql · ~2022</p>
</div>

<div class="project">
  <h3>milo — 4dof robotic arm</h3>
  <p>constructed and programmed a 4dof robotic arm that solved inverse kinematics. designed the electronics in kicad and the mechanics in fusion 360, programmed the stm32 microcontroller in c using the hal library, and built a qt5 visualisation application in c++.</p>
  <p class="tags">c · c++ · stm32 · qt5 · kicad · fusion 360 · ~2022</p>
</div>

<div class="project">
  <h3>ariadna minesweeper — konar team project</h3>
  <p>team project within the konar robotics student interest group. built the project website in html, css, and javascript, and programmed low-level peripherals for the sensorboard module in c for the stm32 microcontroller using the hal library.</p>
  <p class="tags">c · stm32 · html · css · javascript · ~2020</p>
</div>
