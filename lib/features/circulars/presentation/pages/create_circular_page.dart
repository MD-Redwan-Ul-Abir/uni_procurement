import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class CreateCircularPage extends StatefulWidget {
  const CreateCircularPage({super.key});

  @override
  State<CreateCircularPage> createState() => _CreateCircularPageState();
}

class _CreateCircularPageState extends State<CreateCircularPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descController = TextEditingController();
  final _deadlineController = TextEditingController(text: '2026-04-15');

  String _selectedDept = 'Computer Science & Engineering';
  String _selectedCategory = 'IT & Lab Equipment';
  bool _isLoading = false;

  final _departments = [
    'Computer Science & Engineering',
    'Chemistry & Biochemistry',
    'IT & Networking Division',
    'Central University Library',
    'Mechanical Engineering',
    'University Medical Center',
    'Facilities & Engineering',
    'Academic Affairs',
  ];

  final _categories = [
    'IT & Lab Equipment',
    'Scientific Instruments',
    'Network Infrastructure',
    'Automation Software & Hardware',
    'Heavy Machinery',
    'Medical Equipment',
    'Audio/Visual',
    'Classroom Technology',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _descController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final db = Get.find<DummyDatabaseService>();
    final newId = 'CIRC-2026-00${db.circulars.length + 1}';
    final budget = double.tryParse(_budgetController.text.trim()) ?? 50000.0;

    final newCircular = {
      'id': newId,
      'title': _titleController.text.trim(),
      'department': _selectedDept,
      'category': _selectedCategory,
      'estimated_budget': budget,
      'status': 'DRAFT',
      'initiator_id': 2,
      'initiator_name': 'Dr. Sarah Ahmed',
      'publish_date': DateTime.now().toString().split(' ').first,
      'submission_deadline': _deadlineController.text.trim(),
      'awarded_vendor_id': null,
      'awarded_vendor_name': null,
      'awarded_amount': null,
      'description': _descController.text.trim(),
      'bid_count': 0,
    };

    db.addCircular(newCircular);

    // Also register a draft approval tracker
    db.approvalTrackers[newId] = {
      'circular_id': newId,
      'title': _titleController.text.trim(),
      'total_amount': budget,
      'current_step_index': 0,
      'steps': [
        {
          'title': 'Initiation & Draft',
          'role': 'Initiator',
          'assigned_to': 'Dr. Sarah Ahmed',
          'status': 'IN_PROGRESS',
          'date': DateTime.now().toString().split(' ').first,
          'note': 'Draft created. Awaiting submission to Department Head.'
        },
        {
          'title': 'Department Head Review',
          'role': 'Department Head',
          'assigned_to': 'Prof. Tariq Rahman',
          'status': 'PENDING',
          'date': null,
          'note': 'Pending initiation submission.'
        },
        {
          'title': 'Tendering & Evaluation',
          'role': 'Tender Committee',
          'assigned_to': 'Evaluation Committee',
          'status': 'PENDING',
          'date': null,
          'note': 'Pending tender release.'
        },
        {
          'title': 'Dean Approval',
          'role': 'Dean',
          'assigned_to': 'Prof. Kamal Hossain',
          'status': 'PENDING',
          'date': null,
          'note': 'Pending committee report.'
        },
        {
          'title': 'Registrar Sanction & Award',
          'role': 'Registrar',
          'assigned_to': 'Dr. Fatima Noor',
          'status': 'PENDING',
          'date': null,
          'note': 'Final sanction.'
        }
      ]
    };

    setState(() => _isLoading = false);

    AppToast.success(
      title: 'Circular Created',
      description: 'New tender $newId has been saved to the database.',
    );

    Get.offNamed('/circulars');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Procurement Circular'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Requisition & Circular',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the tender specifications to initiate the multi-tier approval workflow.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      AppTextField(
                        controller: _titleController,
                        label: 'Circular Title',
                        hint: 'e.g. High-Performance Computing Cluster for AI Lab',
                        validator: (v) => Validators.required(v, 'Circular title'),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Department',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        )),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedDept,
                                  isExpanded: true,
                                  items: _departments.map((d) {
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(d, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedDept = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Procurement Category',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        )),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedCategory,
                                  isExpanded: true,
                                  items: _categories.map((c) {
                                    return DropdownMenuItem(
                                      value: c,
                                      child: Text(c, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedCategory = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _budgetController,
                              label: 'Estimated Budget (USD)',
                              hint: 'e.g. 85000',
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.required(v, 'Estimated budget'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _deadlineController,
                              label: 'Submission Deadline (YYYY-MM-DD)',
                              hint: '2026-04-15',
                              validator: (v) => Validators.required(v, 'Deadline'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        controller: _descController,
                        label: 'Project Summary & Objectives',
                        hint: 'Explain the purpose and justification for this procurement...',
                        maxLines: 4,
                        validator: (v) => Validators.required(v, 'Summary description'),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            label: 'Cancel',
                            isOutlined: true,
                            onPressed: () => Get.back(),
                          ),
                          const SizedBox(width: 16),
                          AppButton(
                            label: 'Save & Initiate Workflow',
                            isLoading: _isLoading,
                            icon: Icons.send_outlined,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
