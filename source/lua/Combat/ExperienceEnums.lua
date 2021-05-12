-- List of all upgrades available.
kCombatUpgrades = enum({-- Marine upgrades
                        'Mines', 'Welder', 'Shotgun', 'Flamethrower', 'GrenadeLauncher', 'HeavyMachineGun',
                        'Weapons1', 'Weapons2', 'Weapons3', 'Armor1', 'Armor2', 'Armor3',
                        'MotionDetector', 'Scanner', 'Catalyst', 'Resupply', 'ImprovedResupply', 'EMP', 'FastSprint',
                        'Jetpack', 'Exosuit', 'DualMinigunExosuit', 'FastReload',
                        'RailGunExosuit', 'ClusterGrenade', 'GasGrenade', 'PulseGrenade',

                        -- Alien upgrades
                        'Gorge', 'Lerk', 'Fade', 'Onos',
                        'TierTwo', 'TierThree',
                        'Carapace', 'Regeneration', 'Vampirism', 'Camouflage', 'Celerity',
                        'Adrenaline', 'Feint', 'ShadeInk', 'Focus', 'Aura', 'Crush' })

-- The order of these is important...
kCombatUpgradeTypes = enum({'Class', 'Tech', 'Weapon'})