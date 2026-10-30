Install Rogue
=============

Rogue is the SLAC hardware control framework used to interact with
axi-soc-versal-core based designs.  Installation instructions are
maintained upstream in the Rogue documentation.

Follow the Miniforge-based install guide here:

  https://slaclab.github.io/rogue/installing/miniforge.html

The Miniforge method is the recommended approach for SLAC AFS network
users and for standalone workstations alike.  After completing the
upstream steps you will have a conda environment containing ``pyrogue``
and all required dependencies.

The board image runs the Rogue release pinned in
:repo:`shared/Yocto/recipes-apps/rogue/rogue.bb` (``ROGUE_VERSION``,
currently ``6.16.0``) for its TCP bridge.  Keeping the host on the
same release avoids version skew between the two ends of the TCP
connection.  On SLAC AFS hosts, ``software/setup_env_slac.sh`` in
``Simple-VEK280-Example`` activates a matching ``rogue_v6.16.0``
environment.

Once Rogue is installed, see :doc:`rogue_gui_launch` to start the
control GUI for your board.
